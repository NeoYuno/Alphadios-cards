--Vaylantz General Shogun Shoji
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
    -- Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.spconvalue)
	c:RegisterEffect(e0)
	-- Special Summon self or move 1 "Valiants" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.spmvtg)
	c:RegisterEffect(e1)
    --Opponent cannot target "Vaylantz" cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x17e))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    -- Direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.dircon)
	c:RegisterEffect(e3)
    -- Grant ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(function(e,c) return c:IsSetCard(0x17e) and c:HasLevel() or c:HasRank() end)
	e4:SetValue(function(e,c) return c:GetLevel()*100 or c:GetRank()*100 end)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
    -- Special Summon self
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={0x17e}
function s.spconvalue(e,se,sp,st)
	return aux.ritlimit(e,se,sp,st) or se:GetHandler():IsSetCard(0x17e)
end

function s.spmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local mv=s.mvtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return sp or mv end
	local op=Duel.SelectEffect(tp,
		{mv,aux.Stringid(id,0)},
		{sp,aux.Stringid(id,1)})
	if op==1 then
        e:SetCategory(0)
		e:SetOperation(s.mvop)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local zone=(1<<c:GetSequence())&ZONES_MMZ
		return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=(1<<c:GetSequence())&ZONES_MMZ
	if zone~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP,zone)
	end
end
function s.mvfilter(c)
    local z=1<<c:GetSequence()
	return c:GetSequence()<5 and c:IsSetCard(0x17e) and ( c:CheckAdjacent() or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,(z<<1|z>>1)&0x1f)>0)
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
    if tc:IsLocation(LOCATION_MZONE) then
		tc:MoveAdjacent()
	elseif tc:IsLocation(LOCATION_SZONE) then
        local seq=tc:GetSequence()
        if seq>4 then return end
        local flag=0
        if seq>0 and Duel.CheckLocation(tp,LOCATION_SZONE,seq-1) then flag=flag|(0x1<<seq-1) end
        if seq<4 and Duel.CheckLocation(tp,LOCATION_SZONE,seq+1) then flag=flag|(0x1<<seq+1) end
        if flag==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        local zone=math.log(Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,~(flag<<8)),2)-8
        Duel.MoveSequence(tc,zone,LOCATION_SZONE)
    end
end

function s.dirfilter(c,tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp)
end
function s.dircon(e)
	return not e:GetHandler():GetColumnGroup():IsExists(s.dirfilter,1,nil,e:GetHandlerPlayer())
end