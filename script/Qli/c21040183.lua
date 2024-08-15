--Apocqlilypse
local s,id=GetID()
function s.initial_effect(c)
	--Apply 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0xaa}
function s.flagcheck(tp)
	return Duel.GetFlagEffect(tp,id+1)==0,Duel.GetFlagEffect(tp,id+2)==0,Duel.GetFlagEffect(tp,id+3)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1,b2,b3=s.flagcheck(tp)
	if chk==0 then return b1 or b2 or b3 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local b1,b2,b3=s.flagcheck(tp)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if not op then return end
    if op==1 then
        --Piercing damage
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_PIERCE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    elseif op==2 then
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_DESTROY)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_DAMAGE_STEP_END)
        e1:SetCondition(s.togycon)
        e1:SetOperation(s.togyop)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e2:SetRange(LOCATION_SZONE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
        e2:SetLabelObject(e1)
        Duel.RegisterEffect(e2,tp)
    else
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
    Duel.RegisterFlagEffect(tp,id+op,RESET_PHASE+PHASE_END,0,1)
end
function s.togycon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	return t and t:IsRelateToBattle() and t:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.togyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end