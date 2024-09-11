--Ghostrick Mausoleum
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Extra Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8d))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e2)
    --Limit attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e3)
    --Direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.dirtg)
	c:RegisterEffect(e4)
    --negate attack
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.condition)
	e5:SetCost(s.cost)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end
s.listed_series={0x8d}
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end

function s.filter(c)
	return c:IsSetCard(0x8d) and c:IsFacedown() and c:IsDefensePos()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end