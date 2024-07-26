--Selene, the Magistus Celestial Goddess
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
    --Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.speqtg)
	e1:SetOperation(s.speqop)
	c:RegisterEffect(e1)
    --Return to Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
    --untargetable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAGISTUS}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_MAGISTUS,lc,sumtype,tp)
end
function s.monfilter(c,e,tp,ft,sc)
	return c:IsSetCard(SET_MAGISTUS) and c:IsMonster() and c:GetLevel()~=4 and (s.monspfilter(c,e,tp,sc) or s.moneqfilter(c,tp,ft,sc))
end
function s.monspfilter(c,e,tp,sc)
	return Duel.GetMZoneCount(tp,sc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.moneqfilter(c,tp,ft,sc)
	return (ft>0 or sc:GetSequence()<5) and not c:IsForbidden()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MAGISTUS),tp,LOCATION_MZONE,0,1,sc)
end
function s.speqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if chkc then return chkc:IsLocation(LOCATION_SZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.monfilter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.monfilter,tp,LOCATION_STZONE|LOCATION_GRAVE,0,1,nil,e,tp,ft) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.monfilter),tp,LOCATION_STZONE|LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.speqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local sp=s.monspfilter(tc,e,tp)
    local eq=s.moneqfilter(tc,tp,ft,e:GetHandler())
    local op=Duel.SelectEffect(tp,
        {sp,aux.Stringid(id,0)},
        {eq,aux.Stringid(id,1)})
    if op==1 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local ec=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_MAGISTUS),tp,LOCATION_MZONE,0,1,1,e:GetHandler()):GetFirst()
        if not ec then return end
        Duel.HintSelection(ec,true)
        if not Duel.Equip(tp,tc,ec,true) then return end
        --Equip limit
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
        e1:SetLabelObject(ec)
        tc:RegisterEffect(e1)
    end
end

function s.tdfilter(c)
	return c:IsSetCard(SET_MAGISTUS) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,3,nil) 
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end