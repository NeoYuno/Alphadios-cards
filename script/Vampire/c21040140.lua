--Vampire Empire
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetCondition(s.atcon)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
    --take control
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.tkcost)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
    --to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x8e}
function s.atcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
function s.atfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x8e) and c:GetAttack()>atk
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x8e) and Duel.IsExistingMatchingCard(s.atfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end

function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(10)
		return true
	end
end
function s.vamfilter(c,tp)
	local lvrk=c:GetLevel() or c:GetRank()
    if not Duel.CheckLPCost(tp,c:GetAttack()/2) then return false end
    return c:IsFaceup() and c:IsSetCard(0x8e) and Duel.IsExistingMatchingCard(s.tkfilter,tp,0,LOCATION_MZONE,1,nil,lvrk)
end
function s.tkfilter(c,lvrk)
    return c:IsFaceup() and c:GetLevel()>=lvrk and c:IsControlerCanBeChanged()
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		if e:GetLabel()~=10 then return false end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.vamfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
    local tc=Duel.SelectTarget(tp,s.vamfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    Duel.PayLPCost(tp,tc:GetAttack()/2)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    local lvrk=tc:GetLevel() or tc:GetRank()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local sc=Duel.SelectMatchingCard(tp,s.tkfilter,tp,0,LOCATION_MZONE,1,1,nil,lvrk):GetFirst()
    if sc then
        Duel.HintSelection(sc)
        Duel.GetControl(sc,tp)
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e4)
		end
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_CANNOT_ATTACK)
        e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e5:SetReset(RESET_EVENT+RESETS_STANDARD)
        e5:SetCondition(s.atkcon)
        sc:RegisterEffect(e5)
    end
end
function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x8e),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsMonster,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsMonster,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x8e) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end