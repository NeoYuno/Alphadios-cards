--Shinobird's Descent
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.AddProcGreater({
		handler=c,
		filter=s.ritualfil,
		stage2=s.stage2
	})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    --Add back
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={52900000,25415052,id}
s.listed_card_types={TYPE_SPIRIT}
local Shinobird={21040206,21040207,66815913,21040208,92200612,21040209,39817919,52900000,25415052,60823690,33325951,21040210,73055622,9553721,15306543,276357}
function s.ritualfil(c)
	return c:IsCode(52900000,25415052) and c:IsRitualMonster()
end
function s.thfilter(c)
	return c:IsCode(Shinobird) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,60823690,33325951) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=g:Select(tp,1,1,nil)
		if #sg==0 then return end
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.cfilter(c,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP) 
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end