--Blessing of Nephthys
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lvtype=RITPROC_GREATER,extrafil=s.extrafil,extraop=s.extraop,stage2=s.stage2,location=LOCATION_HAND+LOCATION_GRAVE})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--shuffle and draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={8454126}
s.listed_series={0x11f}
function s.ritualfil(c)
	return c:IsSetCard(0x11f) and c:IsRitualMonster()
end
function s.mfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:HasLevel() and c:IsSetCard(0x11f) and c:IsMonster() and c:IsDestructable(e)
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,e)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local rg=mg:Filter(s.mfilter,nil,e)
	local mat2=Group.CreateGroup()
	if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		mat2=rg:FilterSelect(tp,s.mfilter,1,#rg,nil,e)
		mg:Sub(mat2)
	end
	Duel.ReleaseRitualMaterial(mg)
	Duel.Destroy(mat2,REASON_EFFECT)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
    --cannot be negated
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(3308)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    e1:SetCondition(s.con)
    tc:RegisterEffect(e1,true)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.con)
    e2:SetValue(s.efilter)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2,true)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return g:IsExists(Card.IsCode,1,nil,8454126)
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end

function s.tdfilter(c)
	return c:IsSetCard(0x11f) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,5,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	Duel.SendtoDeck(td,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end