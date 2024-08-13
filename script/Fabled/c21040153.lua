--Fabled Overlord
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,99,Synchro.NonTunerEx(s.matfilter),1,1)
    --tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --bounce
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
    --protection
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(function(e,_c) return s.repfilter(_c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
end
s.listed_series={0x35}
function s.matfilter(c,val,sc,sumtype,tp)
	return c:IsSetCard(0x35,sc,sumtype,tp) and c:IsType(TYPE_SYNCHRO,sc,sumtype,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rt=Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return aux.IceBarrierDiscardCost(Card.IsAbleToGraveAsCost,true,1,rt)(e,tp,eg,ep,ev,re,r,rp,0)
        and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
    local rt=Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local ct=aux.IceBarrierDiscardCost(Card.IsAbleToGraveAsCost,true,1,rt)(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local eg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
    Duel.SendtoHand(eg,nil,REASON_EFFECT)
end

function s.repfilter(c,tp)
	return c:IsSetCard(0x35) and c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		return true
	else return false end
end