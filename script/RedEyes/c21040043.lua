-- Red-Eyes Chaos Dragon
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(19025379)
	c:RegisterEffect(e1)
    --Negate the activation of your opponent's card or effect and inflict damage to them
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
    -- Apply effect
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.thcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.listed_names={19025379,21082832}
s.listed_series={0x3b,0xcf,0x10cf}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsMonster() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        if Duel.Damage(1-tp,e:GetHandler():GetBaseAttack()/2,REASON_EFFECT) then
            Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end

function s.blsfilter(c)
    return (c:IsSetCard(0xcf|0x10cf) and c:IsRitualMonster()) or c:IsCode(21082832) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.redfilter(c)
    return c:IsSetCard(0x3b) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=0
	local g1=Duel.GetMatchingGroup(s.blsfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.redfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	if #g1>0 and #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
	elseif #g1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	elseif #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+2
	end
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	elseif op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_GRAVE)
	end
	e:SetLabel(op)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.blsfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
        if #g<=0 then return end
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    elseif e:GetLabel()==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.redfilter),tp,LOCATION_GRAVE,0,1,1,nil)
        if #g<=0 then return end
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
