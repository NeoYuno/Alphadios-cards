--Revitalizing Hot Springs
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --ATK/DEF
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.etarget)
    e1:SetValue(s.ecval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
    --Opponent cannot activate cards or effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.limop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    local e5=e3:Clone()
    e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e5)
    --Gain LP
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
    e6:SetCost(s.lpcost)
	e6:SetTarget(s.lptg)
	e6:SetOperation(s.lpop)
	c:RegisterEffect(e6)
end
s.listed_card_types={TYPE_SPIRIT}
function s.etarget(e,c)
    return not c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
function s.ecval(e,c)
    return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_SPIRIT),e:GetHandler():GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*-300
end

function s.sumfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.sumfilter,1,nil) then
		Duel.SetChainLimitTillChainEnd(function(e,_rp,_tp) return _tp==_rp end)
	end
end

function s.cfilter(c)
	return c:IsDiscardable() and c:IsMonster() and c:IsType(TYPE_SPIRIT) and c:GetDefense()>0
end
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local def=g:GetFirst():GetDefense()
	if def<0 then def=0 end
	e:SetLabel(def)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end