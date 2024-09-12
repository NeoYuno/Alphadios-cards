--Intense Sparks of Flamvell
local s,id=GetID()
function s.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
    --Damage 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg2)
	e2:SetOperation(s.damop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x2c}
s.listed_names={id,76103675}
s.damfilter=aux.FaceupFilter(Card.IsCode,id,76103675)
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)*200
	Duel.SetTargetParam(200+dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)*200
	Duel.Damage(p,200+dam,REASON_EFFECT)
end

function s.confilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x2c)
end
function s.spfilter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(0x2c) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_MZONE,0,nil)
    local sg=g:GetMinGroup(Card.GetLevel)
	if chk==0 then return #sg>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    local dam=sg:GetFirst():GetLevel()*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
