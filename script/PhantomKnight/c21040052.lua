--The Phantom Knights of Broken Cavalry
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),5,2)
	c:EnableReviveLimit()
    --ATK gain
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
    --Set 1 Trap from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
    e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetCondition(s.igncon)
	e2:SetTarget(s.fgtg)
	e2:SetOperation(s.fgop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
    --Apply effects in sequence
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end
function s.atkcon(e)
    local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and c:IsRelateToBattle() and bc and bc:IsLevelAbove(5)
end
function s.atkval(e,c)
    local c=e:GetHandler()
	local bc=c:GetBattleTarget()
    return bc:GetAttack()
end
function s.filter(c)
	return c:GetType()==(TYPE_TRAP) and c:IsSSetable()
end
function s.fgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.fgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetDescription(3300)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e2)
	end
end
function s.igncon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
end
function s.efffilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xdb) and (c:IsAbleToHand() or c:IsAbleToGrave() or c:IsAbleToDeck())
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.efffilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.efffilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.efffilter,tp,LOCATION_REMOVED,0,1,3,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_REMOVED)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg1=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg1,nil,REASON_EFFECT)
    g:RemoveCard(sg1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg2=g:Select(tp,1,1,nil)
    Duel.SendtoGrave(sg2,REASON_EFFECT)
    g:RemoveCard(sg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg3=g:Select(tp,1,1,nil)
    Duel.SendtoDeck(sg3,nil,0,REASON_EFFECT)
end