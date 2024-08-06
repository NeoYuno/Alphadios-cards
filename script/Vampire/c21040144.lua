--Vampire Sovereign
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,4,s.lcheck)
    --tribute limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsHasEffect,id))
	c:RegisterEffect(e1)
    local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
    e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(id)
	e1a:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1a)
    --Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.lpcon)
	e3:SetValue(s.tgvalue)
	c:RegisterEffect(e3)
    --lp gain
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(aux.zptcon(Card.IsFaceup))
    e4:SetTarget(s.rectg)
    e4:SetOperation(s.recop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)
    --Special summon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={0x8e}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x8e,lc,sumtype,tp)
end
function s.tgvalue(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function s.lpcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end

function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsControler(1-tp) or c:IsSetCard(0x8e))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        if tc:GetOwner()==1-tp then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_RACE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(RACE_ZOMBIE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_DISABLE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetCode(EFFECT_DISABLE_EFFECT)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local e4=Effect.CreateEffect(c)
                e4:SetType(EFFECT_TYPE_SINGLE)
                e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e4:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e4)
            end
            local e5=Effect.CreateEffect(c)
            e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_ADD_SETCODE)
            e5:SetValue(0x8e)
            e5:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e5)
        end
	end
end