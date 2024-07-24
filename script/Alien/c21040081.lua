--"A" Cell Reprogramming
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Draw 2 cards
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_A}
function s.filter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:GetCounter(COUNTER_A)>4
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,false)
	local tc=g:GetFirst()
	if tc and Duel.GetControl(tc,tp) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(RACE_REPTILE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local turn_ct=Duel.GetTurnCount()
		--Send it to the GY during the End Phase of the next turn
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,
			function(tc)
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end,
			function()
				return Duel.GetTurnCount()==turn_ct+1
			end,
			nil,2
		)
	end
end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local count=0
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_A,3,REASON_COST) end
    for tc in Duel.GetMatchingGroup(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_A):Iter() do
		count=count+tc:GetCounter(COUNTER_A)
		tc:RemoveAllCounters()
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end