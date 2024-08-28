--Heart of Tundra
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e1:SetValue(function(e,c) return c:GetCounter(0x1015)*300 end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
    --Add counter
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
    --Cannot change battle position
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetTarget(s.bptg)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    --Cannot attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.atktg)
	c:RegisterEffect(e5)
    --Negate effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.distg)
	c:RegisterEffect(e6)
    --Change ATK/DEF
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_SET_ATTACK_FINAL)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetTarget(s.valtg)
	e7:SetValue(0)
	c:RegisterEffect(e7)
    local e8=e7:Clone()
    e8:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e8)
    --Cannot be tributed
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_UNRELEASABLE_SUM)
    e9:SetRange(LOCATION_FZONE)
    e9:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e9:SetTarget(s.mattg)
    e9:SetValue(1)
    c:RegisterEffect(e9)
    local e10=e9:Clone()
    e10:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e10)
    --Cannot be used as Fusion/Synchro/Xyz/Link material
    local e11=e9:Clone()
    e11:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(e11)
    local e12=e9:Clone()
    e12:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(e12)
    local e13=e9:Clone()
    e13:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(e13)
    local e14=e9:Clone()
    e14:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e14)
end
s.counter_list={0x1015}
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		if tc:IsCanAddCounter(0x1015,1) then
			local atk=tc:GetAttack()
			tc:AddCounter(0x1015,1)
		end
	end
end

function s.bptg(e,c)
    return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetCounter(0x1015)>0
end
function s.atktg(e,c)
    return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetCounter(0x1015)>1
end
function s.distg(e,c)
    return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetCounter(0x1015)>2
end
function s.valtg(e,c)
    return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetCounter(0x1015)>3
end
function s.mattg(e,c)
    return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:GetCounter(0x1015)>4
end
