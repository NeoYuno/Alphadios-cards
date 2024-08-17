--Vaylantz Machinex - Von Baron
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),4,2)
	-- Special Summon self or move 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.spmvtg)
	c:RegisterEffect(e1)
    --Banish from gy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
    e2:SetCondition(aux.NOT(s.bancon))
    e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(s.bancon)
	c:RegisterEffect(e3)
    --Place itself into pendulum zone
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.listed_series={0x17e}
function s.spmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local mv=s.mvtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return sp or mv end
	local op=Duel.SelectEffect(tp,
		{sp,aux.Stringid(id,0)},
		{mv,aux.Stringid(id,1)})
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(0)
		e:SetOperation(s.mvop)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local zone=(1<<c:GetSequence())&ZONES_MMZ
		return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=(1<<c:GetSequence())&ZONES_MMZ
	if zone~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.CheckAdjacent,tp,LOCATION_MZONE,0,1,nil) end
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,Card.CheckAdjacent,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		tc:MoveAdjacent()
	end
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,49568943),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil) end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x17e),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.filter(c)
    return c:IsSetCard(0x17e) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
        local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil)
        if not (b1 or b2) then return false end
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            local op=nil
            op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})
            if op==1 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
                local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
                local tc=g:GetFirst()
                local op2=0
                op2=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
                if op2==0 then
                    Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
                else
                    Duel.SendtoExtraP(g,tp,REASON_EFFECT)
                end
            elseif op==2 then
                local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
                aux.ToHandOrElse(tc,tp,
                    function(c)
                        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden() and c:CheckUniqueOnField(tp)
                    end,
                    function(c)
                        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                        --Treated as a Continuous Spell
                        local e1=Effect.CreateEffect(tc)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e1:SetCode(EFFECT_CHANGE_TYPE)
                        e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
                        e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
                        tc:RegisterEffect(e1)
                    end,
                    aux.Stringid(id,7)
                )
            end
        end
	end
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end