--Ghostrick Leprechaun
local s,id=GetID()
function s.initial_effect(c)
	--Summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)
	--Change itself to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end
s.listed_series={0x8d}
function s.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
function s.sumcon(e)
	return not Duel.IsExistingMatchingCard(s.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setfilter(c)
	return c:IsSetCard(0x8d) and c:IsSpellTrap() and c:IsSSetable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rec=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x8d),tp,LOCATION_ONFIELD,0,nil)*500
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
    local b2=rec>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
    local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
    e:SetLabel(op)
    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
    end
    if op==2 then
        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(rec)
        Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
    end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rec=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x8d),tp,LOCATION_ONFIELD,0,nil)*500
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    if e:GetLabel()==1 then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x8d) end)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
        -- Clock Lizard check
        aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalSetCard(0x8d) end)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
	if e:GetLabel()==2 then
        if Duel.Recover(p,rec,REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
            if tc then
                Duel.BreakEffect()
                Duel.SSet(tp,tc)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(aux.Stringid(86605515,2))
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e1:SetCondition(s.triggercon)
                e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
                tc:RegisterEffect(e1)
            end
        end
    end
end
function s.triggercon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x8d),tp,LOCATION_MZONE,0,1,nil)
end