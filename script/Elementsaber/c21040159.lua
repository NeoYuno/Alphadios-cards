--The Prime Elemental
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,2,nil,nil,nil,nil,false,s.xyzcheck)
    --Attribute change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.attval)
	c:RegisterEffect(e1)
    --spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetTarget(s.sslimit)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    c:RegisterEffect(e3)
    --Apply effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e5:SetCondition(s.quickcon)
	c:RegisterEffect(e5,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_ELEMENTAL_LORD}
local mask=ATTRIBUTE_EARTH|ATTRIBUTE_FIRE|ATTRIBUTE_WATER|ATTRIBUTE_WIND|ATTRIBUTE_LIGHT|ATTRIBUTE_DARK
local attributes=0
local resolveattribute=0
function s.xyzcheck(g,tp,xyz)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.attval(e,c)
	local og=e:GetHandler():GetOverlayGroup()
	return og:GetBitwiseOr(Card.GetAttribute)
end
function s.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
    local att=e:GetHandler():GetAttribute()
	return c:IsAttribute(att)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_ELEMENTAL_LORD)
end
function s.attfilter(c,tp)
	return (c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_FIRE) and Duel.GetMatchingGroupCount(Card.IsMonster,tp,0,LOCATION_MZONE,nil)>0)
	    or (c:IsAttribute(ATTRIBUTE_WATER|ATTRIBUTE_WIND) and Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)>0)
		or (c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and Duel.GetMatchingGroupCount(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)>0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	for tc in aux.Next(g) do
		attributes=attributes|(tc:GetAttribute()&mask)
	end
	local b1=Duel.GetMatchingGroupCount(Card.IsMonster,tp,0,LOCATION_MZONE,nil)>0 and attributes&ATTRIBUTE_EARTH>0 or attributes&ATTRIBUTE_FIRE>0
    local b2=Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)>0 and attributes&ATTRIBUTE_WATER>0 or attributes&ATTRIBUTE_WIND>0
    local b3=Duel.GetMatchingGroupCount(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)>0 and attributes&ATTRIBUTE_DARK>0 or attributes&ATTRIBUTE_LIGHT>0
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and (b1 or b2 or b3) end
	local sc=g:FilterSelect(tp,s.attfilter,1,1,nil,tp)
	Duel.SendtoGrave(sc,REASON_COST)
	local tc=sc:GetFirst()
	resolveattribute=resolveattribute|(tc:GetAttribute()&mask)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabel()
	if resolveattribute&ATTRIBUTE_EARTH>0 or resolveattribute&ATTRIBUTE_FIRE>0 then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if resolveattribute&ATTRIBUTE_WATER>0 or resolveattribute&ATTRIBUTE_WIND>0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if resolveattribute&ATTRIBUTE_DARK>0 or resolveattribute&ATTRIBUTE_LIGHT>0 then
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
		for tc in aux.Next(g) do
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_ELEMENTAL_LORD)
end