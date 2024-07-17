-- Prelude to Chaos
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	-- Add back to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(aux.exccon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Mentions "BLS" and "Gaia" Archetypes
s.listed_series={0x10cf,0xbd}
s.counter_place_list={COUNTER_SPELL}

-- ACtivate
function s.costfilter1(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:HasLevel() and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
		and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetAttribute(),c:GetLevel(),c:GetAttack(),c:GetDefense())
end
function s.thfilter1(c,att,lv,atk,def)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and not c:IsAttribute(att) and c:IsLevel(lv) 
	    and c:IsAttack(atk) and c:IsDefense(def) and c:IsAbleToHand()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter1,1,true,nil,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.costfilter1,1,1,true,nil,nil,tp):GetFirst()
	e:SetLabelObject(tc)
	Duel.Release(tc,REASON_COST)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==100 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttribute(),tc:GetLevel(),tc:GetAttack(),tc:GetDefense())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.costfilter2(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSetCard(0x10cf) or c:IsSetCard(0xbd)
end
function s.revfilter1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsMonster() and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.IsExistingMatchingCard(s.revfilter2,tp,LOCATION_DECK,0,1,c,c:GetAttribute(),c:GetLevel(),c:GetAttack(),c:GetDefense()) and not c:IsPublic()
end
function s.revfilter2(c,att,lv,atk,def)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsMonster() and c:HasLevel() and c:IsAbleToHand() 
	    and not c:IsAttribute(att) and c:IsLevel(lv) and c:IsAttack(atk) and c:IsDefense(def) and not c:IsPublic()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return 
		Duel.CheckReleaseGroupCost(tp,s.costfilter2,1,false,nil,nil) and Duel.IsExistingMatchingCard(s.revfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.costfilter2,1,1,false,nil,nil):GetFirst()
	if Duel.Release(tc,REASON_COST)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.revfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g2=Duel.SelectMatchingCard(tp,s.revfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttribute(),tc:GetLevel(),tc:GetAttack(),tc:GetDefense())
		g2:AddCard(tc)
		Duel.ConfirmCards(1-tp,g2)
		Duel.SetTargetCard(g2)
	end
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToHand,1,c,REASON_EFFECT)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp,g)
	if #sg==1 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		Duel.SendtoHand(g:Sub(sg),nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Add back to hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_SPELL,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,COUNTER_SPELL,2,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end