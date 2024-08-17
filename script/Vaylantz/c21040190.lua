--Vaylantz Machinex - Von Baron
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	-- Special Summon self or move 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.spmvtg)
	c:RegisterEffect(e1)
    --tohand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --Place itself into pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.listed_series={0x17e}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,scard,sumtype,tp)
end
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

function s.thfilter(c)
    return c:IsFaceup() and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hg>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,75952542),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tc=hg:RandomSelect(tp,1)
            Duel.BreakEffect()
			Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)
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