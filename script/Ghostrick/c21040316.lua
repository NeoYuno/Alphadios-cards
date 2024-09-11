--Ghostrick Merry Trick-mas
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCost(s.descost)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCondition(s.gyspcon)
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={0x8d}
function s.costfilter(c)
	return c:IsSetCard(0x8d) and c:IsMonster() and c:IsFacedown()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=#sg
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ghostrickgroup=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE,0,nil)
    local destroygroup=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    if chk==0 then return #ghostrickgroup>0 and #destroygroup>0 end
    local sg=aux.SelectUnselectGroup(ghostrickgroup,e,tp,1,#destroygroup,s.rescon,1,tp,HINTMSG_CONFIRM)
    Duel.ConfirmCards(1-tp,sg)
    e:SetLabel(#sg)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,e:GetLabel(),e:GetLabel(),nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.gyspcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
function s.gyspfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 then
			if tc:IsFacedown() then
				Duel.ConfirmCards(1-tp,tc)
			end
		end
    end
end