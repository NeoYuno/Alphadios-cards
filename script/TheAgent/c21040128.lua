--Miraculous Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -- Recover
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
    --Shuffle
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SANCTUARY_SKY}
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_FAIRY),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_FAIRY),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end

function s.tdfilter(c,tohand)
	return c:IsRace(RACE_FAIRY) and c:IsMonster() and (c:IsAbleToDeck() or (tohand and c:IsAbleToHand()))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tohand=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SANCTUARY_SKY),tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc,tohand) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil,tohand) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil,tohand)
	if not tohand then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local tohand=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SANCTUARY_SKY),tp,LOCATION_ONFIELD,0,1,nil)
	if tohand then
		aux.ToHandOrElse(tc,tp,
				function() return tc:IsAbleToDeck() end,
				function() Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end,
				aux.Stringid(28189908,2)
		)
	else
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end