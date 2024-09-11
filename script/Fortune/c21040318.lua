--Fortune's Watch
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
    --Increase the Level of all "Fortune Lady" monsters you currently control by 1
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
    --The Levels of all "Fortune Lady" monsters you currently control becomes equal to the Level of the Spellcaster monster you control with the highest Level
    local e3=e2:Clone()
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetOperation(s.lvop2)
    c:RegisterEffect(e3)
end
s.listed_series={0x31,0x12e}
function s.etarget(e,c)
    return c:IsSetCard(0x31) or c:IsSetCard(0x12e) and c:IsFaceup() and c:IsMonster()
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x31),tp,LOCATION_MZONE,0,1,nil) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x31),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local lvc=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetLevel):GetFirst()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x31),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(lvc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCountLimit(1)
        e2:SetOperation(s.op)
        tc:RegisterEffect(e2,true)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e:GetHandler():RegisterEffect(e1)
end