--Mauvebeard, the Plunder Patroll Quartermaster
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local e1=Effect.CreateEffect(c)
    local params = {aux.FilterBoolFunction(Card.IsSetCard,0x13f),Fusion.OnFieldMat,nil,nil,Fusion.ForcedHandler,s.stage2}
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
    --Synchro/Xyz/Link Summon
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.extrasumtg)
	e2:SetOperation(s.extrasumop)
	c:RegisterEffect(e2)
    --Apply Effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.effcon)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={0x13f}
function s.syncfilter(c,must)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(must)
end
function s.xyzfilter(c,must)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_XYZ) and c:IsXyzSummonable(must)
end
function s.linkfilter(c,must)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(must)
end
function s.extrasumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,c)
	local b2=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,c)
	local b2=Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,c)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.extrasumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local op=e:GetLabel()
	if op==1 then
		local g=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_EXTRA,0,nil,c)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
			e1:SetOperation(s.regop)
			e1:SetLabelObject(c)
			sc:RegisterEffect(e1)
			Duel.SynchroSummon(tp,sc,c)
		end
	elseif op==2 then
		local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,c)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.XyzSummon(tp,sc,c)
		end
    elseif op==3 then
        local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_EXTRA,0,nil,c)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.LinkSummon(tp,sc,c)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
			e1:SetOperation(s.regop)
			e1:SetLabelObject(c)
			sc:RegisterEffect(e1)
		end
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local sc=e:GetHandler()
	local tc=e:GetLabelObject()
	if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Equip(tp,tc,sc,true)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
		local e1=Effect.CreateEffect(sc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end

function s.stage2(e,tc,tp,mg,chk)
    local c=e:GetHandler()
	if chk==1 and c:IsLocation(LOCATION_GRAVE) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        Duel.Equip(tp,c,tc,true)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(s.eqlimit)
        e1:SetLabelObject(tc)
        c:RegisterEffect(e1)
    end
end

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
end
function s.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if chk==0 then return b1 or b2 end
    local op=0
    op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,7)},{b2,aux.Stringid(id,8)})
    e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if e:GetLabel()==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    elseif e:GetLabel()==2 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
    end
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,6))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(0x13f) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end