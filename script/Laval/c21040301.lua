--Laval Patriarch
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,1,Synchro.NonTuner(nil),1,99)
    --Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --banish and summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x39}
function s.thfilter(c)
	return c:ListsArchetype(0x39) and c:IsAbleToHand()
end
function s.tgfilter(c)
	return c:Attribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #tg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local sg=tg:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

function s.spcheck(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_TOFIELD)>=#sg and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,#sg,nil,e,tp)
end
function s.costfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x39) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,99,s.spcheck,0) end
    local ct=5
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.spcheck,1,tp,HINTMSG_REMOVE)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_COST)~=0 then
		ct=math.min(#(Duel.GetOperatedGroup()),Duel.GetLocationCount(tp,LOCATION_MZONE))
    end
    e:SetLabel(ct)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
    --Cannot Special Summon, except FIRE monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,card) return card:IsAttributeExcept(ATTRIBUTE_FIRE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,ct,ct,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end