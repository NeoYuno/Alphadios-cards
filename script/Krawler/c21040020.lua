-- World Legacy Intricate Spindle
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Change Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cecon)
	e1:SetTarget(s.cetg)
	e1:SetOperation(s.ceop)
	c:RegisterEffect(e1)
    -- Change Position and Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end

-- Mentions "Krawler" Archetype
s.listed_series={0x104}

-- Change Effect
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL|TYPE_TRAP) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x104),tp,LOCATION_MZONE,0,1,nil)
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,rp,0,LOCATION_MZONE,1,nil) end
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #sg>0 then
		aux.RemoveUntil(sg,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
	end
end

-- Change Position and Set
function s.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104) and c:IsCanTurnSet()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsSSetable() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc1=Duel.GetFirstTarget()
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and Duel.ChangePosition(tc1,POS_FACEDOWN_DEFENSE)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsSSetable() then
            Duel.SSet(tp,c)
        end
	end
end