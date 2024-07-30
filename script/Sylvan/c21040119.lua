--Sylvan Uproot
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --shuffle or add back
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=Duel.GetMatchingGroup(Card.IsSequence,tp,LOCATION_DECK,0,nil,0):GetFirst()
	if chk==0 then return sc and sc:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.GetMatchingGroup(Card.IsSequence,tp,LOCATION_DECK,0,nil,0):GetFirst()
	if sc:IsAbleToHand() then
        Duel.SendtoHand(sc,nil,REASON_EFFECT)
    end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
    local sg=g:Filter(Card.IsMonster,nil)
	if #sg>0 then
        local tc=sg:GetFirst()
        if tc:IsRace(RACE_PLANT) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.DisableShuffleCheck()
            Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
            Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
        else
            Duel.DisableShuffleCheck()
            Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
            Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
        end
	end
	ac=ac-#sg
	if ac>0 then
		Duel.MoveToDeckBottom(ac,tp)
		Duel.SortDeckbottom(tp,tp,ac)
	end
end