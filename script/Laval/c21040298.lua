--Laval Blader
local s,id=GetID()
function s.initial_effect(c)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    --Return banished monsters to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
    e4:SetCost(s.tgcost)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
s.listed_series={0x39}
function s.setfilter(c)
	return c:ListsArchetype(0x39) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetBaseAttack()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

function s.tgfilter(c,e)
	return c:IsMonster() and c:IsFaceup() and c:IsSetCard(0x39)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,3,nil)
    local ct=Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
    e:SetLabel(ct)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabel()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x39),tp,LOCATION_MZONE,0,nil)
    if ct>0 and #g>0 then
        for tc in aux.Next(g) do
            --Cannot be destroyed by battle
            local e1=Effect.CreateEffect(tc)
            e1:SetDescription(3000)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e1)
            --Increase ATK
            local e2=Effect.CreateEffect(tc)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(100)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
    if ct>1 and #g>0 then
        for tc in aux.Next(g) do
            --Cannot be destroyed by card effects
            local e1=Effect.CreateEffect(tc)
            e1:SetDescription(3001)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e1)
            --Increase ATK
            local e2=Effect.CreateEffect(tc)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(200)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
    if ct==3 and #g>0 then
        for tc in aux.Next(g) do
            --Cannot be targeted by card effects
            local e1=Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e1)
            --Increase ATK
            local e2=Effect.CreateEffect(tc)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(300)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end