--Apoqliphort Tierra
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.splimcon)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
    --Cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0xaa) and c:IsStatus(STATUS_SUMMON_TURN) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    --Place 1 Pendulum monster in the Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
    e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetValue(s.zones)
	e3:SetCost(s.scalecost)
	e3:SetTarget(s.scaletg)
	e3:SetOperation(s.scaleop)
	c:RegisterEffect(e3)
    --Cannot be Special Summoned
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e4)
	--Must be Tribute Summoned by using "Qli" monsters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_TRIBUTE_LIMIT)
	e5:SetValue(s.tlimit)
	c:RegisterEffect(e5)
	--Summon with 3 tribute
	local e6=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(27279764,0))
	local e7=aux.AddNormalSetProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(27279764,0))
	--Unaffected by cards' effects
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) end)
	e8:SetValue(s.efilter)
	c:RegisterEffect(e8)
    --tohand
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_TOHAND)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_SUMMON_SUCCESS)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetTarget(s.thtg)
	e9:SetOperation(s.thop)
	c:RegisterEffect(e9)
    local e10=e9:Clone()
    e10:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e10)
    --Destroy 1 pendulum monster
	local e11=Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_DESTROY)
	e11:SetType(EFFECT_TYPE_IGNITION)
	e11:SetRange(LOCATION_MZONE)
	e11:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e11:SetCountLimit(1)
	e11:SetTarget(s.destg)
	e11:SetOperation(s.desop)
	c:RegisterEffect(e11)
end
s.listed_series={0xaa}
function s.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
function s.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
function s.tlimit(e,c)
	return not c:IsSetCard(SET_QLI)
end
function s.efilter(e,te)
	if te:IsSpellTrapEffect() then
		return true
	else
		return aux.qlifilter(e,te)
	end
end

function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	if Duel.IsDuelType(DUEL_SEPARATE_PZONE) then return zone end
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if p0==p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
function s.scalecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHandAsCost,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHandAsCost,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.pendfilter(c)
	return c:IsSetCard(0xaa) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and not c:IsForbidden() and not c:IsCode(id)
end
function s.scaletg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,nil) end
end
function s.scaleop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pendfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	if chk==0 then return e:GetHandler():IsType(TYPE_PENDULUM) and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end