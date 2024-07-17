-- Cyberdark Replica
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
    -- Equip
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.eqcon)
    e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    --cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_EQUIP))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
s.listed_series={0x4093}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x4093,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.eqcon(e)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup()
	return not eg:IsExists(Card.IsOriginalType,1,nil,TYPE_MONSTER)
end
function s.cfilter(c)
	return c:IsSetCard(0x4093) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.eqfilter(c,ec)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsLevelBelow(4)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,c):GetFirst()
		if ec and Duel.Equip(tp,ec,c) then
            local atk=ec:GetTextAttack()
            if atk<0 then atk=0 end
            --Equip limit
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            e1:SetLabelObject(c)
            ec:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_EQUIP)
            e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetValue(atk/2)
            ec:RegisterEffect(e2,true)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_EQUIP)
            e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            e3:SetValue(s.repval)
            ec:RegisterEffect(e3,true)
		end
        Duel.EquipComplete()
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.repval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end