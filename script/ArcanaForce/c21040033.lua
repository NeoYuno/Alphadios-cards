-- Knight of Pentacles
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
    -- Set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
    -- Choose result
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TOSS_COIN_NEGATE)
    e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.coincon)
	e3:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
		return Duel.AnnounceCoin(c:GetOwner(),aux.Stringid(300102004,4))
	end))
	c:RegisterEffect(e3)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function s.setfilter(c)
	return c:ListsArchetype(SET_ARCANA_FORCE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct==1 and ep==tp then
		return true
	else return false end
end
function s.repop(isdice,func2,func3)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
            Duel.Hint(HINT_CARD,tp,id)
            local total=(ev&0xff)+(ev>>16)
            local res={}
            res[1]=func3(ep)
            for i=2,total do
                table.insert(res,Duel.GetRandomNumber(0,1)==0 and COIN_TAILS or COIN_HEADS)	
            end
            func2(table.unpack(res))
        end
    end
end