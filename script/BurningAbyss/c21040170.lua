--Malacoda, Supreme Netherlord of the Burning Abyss
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
    -- Effect destruction protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb1))
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb1))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
    --Apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.applytg)
	e3:SetOperation(s.applyop)
	c:RegisterEffect(e3)
    --banish
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.banishtg)
	e4:SetOperation(s.banishop)
	c:RegisterEffect(e4)
end
s.listed_series={0xb1}
function s.matcheck(g,lnkc,sumtype,sp)
	return g:IsExists(Card.IsSetCard,1,nil,0xb1,lnkc,sumtype,sp)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end

function s.Phlegyasfilter(c,e)
    return c:IsCode(21040166) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end

function s.Charonfilter(c,e,tp)
    return c:IsCode(21040167) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.tgfilter(c)
	return c:IsSetCard(0xb1) and (c:IsAbleToGrave() or c:IsSSetable())
end

function s.Barbarfilter(c,e,tp)
    return c:IsCode(81992475) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function s.rmfilter(c)
	return c:IsSetCard(0xb1) and not c:IsCode(81992475) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end

function s.Cirfilter(c,e,tp)
    return c:IsCode(57143342) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xb1) and not c:IsCode(57143342) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.Cagnafilter(c,e,tp)
    return c:IsCode(9342162) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.tgfilter(c)
	return c:IsSetCard(0xb1) and c:IsSpellTrap() and c:IsAbleToGrave()
end

function s.Calcabfilter(c,e,tp)
    return c:IsCode(73213494) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
end
function s.thfilter2(c)
	return c:IsFacedown() and c:IsAbleToHand()
end

function s.Libicfilter(c,e,tp)
    return c:IsCode(62957424) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.spfilter2(c,e,tp)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.Alichfilter(c,e,tp)
    return c:IsCode(47728740) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.Draghigfilter(c,e,tp)
    return c:IsCode(45593826) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xb1)
end

function s.Farfafilter(c,e,tp)
    return c:IsCode(36553319) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.Grafffilter(c,e,tp)
    return c:IsCode(20758643) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_DECK,0,1,nil,e,tp)
end

function s.Scarmfilter(c,e,tp)
    return c:IsCode(84764038) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
function s.thfilter3(c)
	return c:GetLevel()==3 and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
		and not c:IsCode(84764038) and c:IsAbleToHand()
end

function s.Neitherlordfilter(c,e,tp)
    return c:IsCode(35330871) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.Pilgrimfilter(c,e,tp)
    return c:IsCode(18386170) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end

function s.Vigilantfilter(c,e,tp)
    return c:IsCode(21040169) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.Virgilfilter(c,e,tp)
    return c:IsCode(601193) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1)
end

function s.Beatricefilter(c,e,tp)
    return c:IsCode(27552504) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.spfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end
function s.spfilter4(c,e,tp)
	return c:IsSetCard(0xb1) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.Dantefilter(c,e,tp)
    return c:IsCode(83531441) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,Card.IsCode(83531441))
end

function s.Supremefilter(c,e,tp)
    return c:IsCode(id) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE0,LOCATION_GRAVE,1,nil)
end

function s.applyfilter(c,e,tp)
	return s.Phlegyasfilter(c,e) or s.Charonfilter(c,e,tp) or s.Barbarfilter(c,e,tp) or s.Cirfilter(c,e,tp) or s.Cagnafilter(c,e,tp) or s.Calcabfilter(c,e,tp) or s.Libicfilter(c,e,tp)
        or s.Alichfilter(c,e,tp) or s.Draghigfilter(c,e,tp) or s.Farfafilter(c,e,tp) or s.Grafffilter(c,e,tp) or s.Scarmfilter(c,e,tp) or s.Neitherlordfilter(c,e,tp) or s.Pilgrimfilter(c,e,tp)
        or s.Vigilantfilter(c,e,tp) or s.Virgilfilter(c,e,tp) or s.Beatricefilter(c,e,tp) or s.Dantefilter(c,e,tp) or s.Supremefilter(c,e,tp)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.applyfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.applyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.applyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if tc:IsCode(21040166) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetOperation(s.thspop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(21040167) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21040167,0))
        local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
        if not tc then return end
        local op=nil
        if tc:IsRitualMonster() then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
        else
            op=Duel.SelectOption(tp,aux.Stringid(21040167,1),aux.Stringid(21040167,2))
        end
        if op==0 then
            if (tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
                Duel.ConfirmCards(1-tp,tc)
            elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
                and tc:IsSSetable() then
                Duel.BreakEffect()
                Duel.SSet(tp,tc)
            end
        else
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(81992475) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,3,nil)
        Duel.HintSelection(g)
        if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
            local rg=Duel.GetOperatedGroup()
            local ct=rg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
            if ct>0 then
                Duel.Damage(1-tp,ct*300,REASON_EFFECT)
            end
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(57143342) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        Duel.HintSelection(g)
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(9342162) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(73213494) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
        Duel.HintSelection(g)
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(62957424) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2,true)
        end
        Duel.SpecialSummonComplete()
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(47728740) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
        local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        Duel.HintSelection(g)
        local tc2=g:GetFirst()
        Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc2:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc2:RegisterEffect(e2)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(45593826) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45593826,2))
        local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xb1)
        local tc2=g:GetFirst()
        if tc2 then
            Duel.ShuffleDeck(tp)
            Duel.MoveSequence(tc2,0)
            Duel.ConfirmDecktop(tp,1)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(36553319) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        Duel.HintSelection(g)
        Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)
        local tc2=g:GetFirst()
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc2)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(20758643) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(84764038) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetOperation(s.thop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(35330871) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.HintSelection(g)
        Duel.SendtoGrave(g,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(18386170) then
        local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
        if #g==0 then return end
        local sg=g:RandomSelect(tp,1)
        Duel.SendtoGrave(sg,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(21040169) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
        Duel.SetChainLimit(s.chlimit)
        Duel.Destroy(g,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(601193) then
        Duel.Draw(tp,1,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(27552504) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(83531441) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,Card.IsCode(83531441))
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    if tc:IsCode(id) then
        local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,3,nil)
            Duel.HintSelection(sg)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

function s.thspfilter(c,e,tp,ft)
	return c:IsSetCard(0xb1) and c:IsLevelAbove(6) and (c:IsAbleToHand()
		or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(20357457,4)
	)
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.chlimit(e,ep,tp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return tp==ep or not g:IsContains(e:GetHandler())
end

function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,3,nil)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end