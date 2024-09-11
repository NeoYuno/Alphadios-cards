--Gishki Torterugaus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    -- Treat as entire tribute requirement
	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
    --Look at 1 random card and shuffle it into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GISHKI}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
	local op=Duel.SelectOption(tp,70,71,72)
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1):GetFirst()
	Duel.ConfirmCards(tp,tc)
	local typ=e:GetLabel()
    if e:GetLabel()==0 then
		--Unaffected by opponent's monster effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3111)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GISHKI))
        e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.imfilter1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif e:GetLabel()==1 then
		--Unaffected by opponent's spell effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3112)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GISHKI))
        e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.imfilter2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif e:GetLabel()==2 then
		--Unaffected by opponent's trap effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3113)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GISHKI))
        e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.imfilter3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if (tc:IsType(TYPE_MONSTER) and e:GetLabel()==0) or (tc:IsType(TYPE_SPELL) and e:GetLabel()==1) or (tc:IsType(TYPE_TRAP) and e:GetLabel()==2) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	else Duel.ShuffleHand(1-tp) end
end
function s.imfilter1(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.imfilter2(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.imfilter3(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end