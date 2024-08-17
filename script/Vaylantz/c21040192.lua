--Vaylantz Negotiator
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
    --Place 1 Pendulum Monster in the Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
    --Move
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
end
s.listed_series={0x17e}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x17e,lc,sumtype,tp)
end

function s.plfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end

function s.mvfilter(c,tp)
    local z=1<<c:GetSequence()
	return c:GetSequence()<5 and c:IsOriginalType(TYPE_MONSTER) and (c:CheckAdjacent() or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,(z<<1|z>>1)&0x1f)>0)
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:CheckAdjacent() end
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.mvfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
end
function s.tdfilter(c,tc)
    return not c:GetColumnGroup():IsContains(tc)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        if tc:IsLocation(LOCATION_MZONE) then
            tc:MoveAdjacent()
        elseif tc:IsLocation(LOCATION_SZONE) then
            local seq=tc:GetSequence()
            if seq>4 then return end
            local flag=0
            if seq>0 and Duel.CheckLocation(tp,LOCATION_SZONE,seq-1) then flag=flag|(0x1<<seq-1) end
            if seq<4 and Duel.CheckLocation(tp,LOCATION_SZONE,seq+1) then flag=flag|(0x1<<seq+1) end
            if flag==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
            local zone=math.log(Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,~(flag<<8)),2)-8
            Duel.MoveSequence(tc,zone,LOCATION_SZONE)
        end
        local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,tc)
        if tc:IsSetCard(0x17e) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local tg=g:Select(tp,1,1,nil)
            Duel.BreakEffect()
            Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end