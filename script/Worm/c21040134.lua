--Colony – Worm Origin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_REPTILE))
	e1:SetValue(300)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
    -- Change Position and Set
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
    --Fusion
    local e4=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),aux.TRUE,s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
    e4:SetDescription(aux.Stringid(id,4))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
    e4:SetCondition(s.fuscon)
	c:RegisterEffect(e4)
end
s.listed_series={0x3e}
local WNebula={21040132,21040135,21040133,90075978,21040136}
function s.thfilter(c)
    return c:IsCode(WNebula) and c:IsAbleToHand()
end
function s.flipfaceupfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
function s.flipfacedownfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.flipfaceupfilter,tp,LOCATION_MZONE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.flipfacedownfilter,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return b1 or b2 end
    local op=nil
	op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
    e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local tc=Duel.SelectMatchingCard(tp,s.flipfaceupfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if Duel.ChangePosition(tc,POS_FACEUP_ATTACK) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
            if #sc==0 then return end
            Duel.BreakEffect()
            Duel.SendtoHand(sc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sc)
        end
    elseif e:GetLabel()==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local tc=Duel.SelectMatchingCard(tp,s.flipfacedownfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
            if #sc==0 then return end
            Duel.BreakEffect()
            Duel.SendtoHand(sc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sc)
        end
    end
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
function s.checkmat(tp,sg,fc)
	return fc:IsRace(RACE_REPTILE) and sg:GetClassCount(Card.GetCode)==#sg and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)
end
function s.fextra(e,tp,mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.checkmat
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(_,c) return not c:IsRace(RACE_REPTILE) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
    end
end