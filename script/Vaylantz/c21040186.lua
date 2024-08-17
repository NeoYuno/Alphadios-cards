--Alkatraz the Vaylantz Legionnaire
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
    -- Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.spconvalue)
	c:RegisterEffect(e0)
    -- Special Summon self
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- Move 1 other monster to an adjacent zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
    -- Add 1 excavated card
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x17e}
function s.spconvalue(e,se,sp,st)
	return aux.ritlimit(e,se,sp,st) or se:GetHandler():IsSetCard(0x17e)
end

function s.spconfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VAYLANTZ)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x17e),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		or Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local zone=(1<<c:GetSequence())&ZONES_MMZ
		return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=(1<<c:GetSequence())&ZONES_MMZ
	if zone~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP,zone)
	end
end

function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c~=chkc and chkc:IsLocation(LOCATION_MZONE) and chkc:CheckAdjacent() end
	if chk==0 then return Duel.IsExistingTarget(Card.CheckAdjacent,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.CheckAdjacent,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		tc:MoveAdjacent(tp)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_VAYLANTZ) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return end
	local dc=Duel.TossDice(tp,1)
	Duel.ConfirmDecktop(tp,dc)
    local g=Duel.GetDecktopGroup(tp,dc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil,tp)
	if #sg>0 then
		Duel.DisableShuffleCheck(true)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
	end
end