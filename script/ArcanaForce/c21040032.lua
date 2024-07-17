-- Arcana Force XIX - The Sun
-- Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- Toss a coin and apply the appropriate effect
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ARCANA_FORCE}
s.toss_coin=true
function s.spfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(SET_ARCANA_FORCE) and c:IsAbleToHandAsCost()
		and (ft>0 or c:GetSequence()<5)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,ft)
	return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,ft)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end

function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	s.arcanareg(c,Arcana.TossCoin(c,tp))
end
function s.arcanareg(c,coin)
	-- Heads Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ARCANA_FORCE))
    e1:SetCondition(s.indcon)
	e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_TOSS_COIN_CHOOSE)
    e3:SetRange(LOCATION_MZONE)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	e3:SetCondition(s.coincon)
	e3:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
		return Duel.AnnounceCoin(c:GetOwner(),aux.Stringid(300102004,4))
	end))
	Duel.RegisterEffect(e3,c:GetOwner())
    -- Tails Effect
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ARCANA_FORCE))
    e4:SetCondition(s.bpcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
    e5:SetCondition(s.swcon)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	Arcana.RegisterCoinResult(c,coin)
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Arcana.GetCoinResult(e:GetHandler())==COIN_HEADS
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Arcana.GetCoinResult(e:GetHandler())==COIN_HEADS
end
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return Arcana.GetCoinResult(e:GetHandler())==COIN_TAILS
end
function s.swcon(e,tp,eg,ep,ev,re,r,rp)
	return Arcana.GetCoinResult(e:GetHandler())==COIN_TAILS
end
function s.repop(isdice,func2,func3)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
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
function s.aefilter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:GetFlagEffect(CARD_REVERSAL_OF_FATE)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsOnField() and s.aefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.aefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.aefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and s.aefilter(tc) then
		local val=Arcana.GetCoinResult(tc)
		if val==COIN_HEADS then
			Arcana.SetCoinResult(tc,COIN_TAILS)
		elseif val==COIN_TAILS then
			Arcana.SetCoinResult(tc,COIN_HEADS)
		end
	end
end