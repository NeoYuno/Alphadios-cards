--Arktos X – Temporalchasm Vaylantz
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c)
    Fusion.AddProcMixN(c,true,true,s.ffilter,2)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	-- Special Summon self or move 1 "Valiants" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.spmvtg)
	c:RegisterEffect(e1)
    --Shuffle all cards
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
    --force mzone
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_FORCE_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.limitval)
	c:RegisterEffect(e4)
end
s.listed_series={0x17e}
function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsSetCard(0x17e,fc,sumtype,sp) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sp))
end

function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
    local tp=g:GetFirst():GetControler() and g:GetNext():GetControler()
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
    local og=Duel.GetOperatedGroup()
    if og:IsExists(Card.IsLevelAbove,1,nil,5) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
end
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return not (c:IsLocation(LOCATION_EXTRA) and c:IsFacedown())
end

function s.spmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local mv=s.mvtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return sp or mv end
	local op=Duel.SelectEffect(tp,
		{mv,aux.Stringid(id,0)},
		{sp,aux.Stringid(id,1)})
	if op==1 then
        e:SetCategory(0)
		e:SetOperation(s.mvop)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local zone=(1<<c:GetSequence())&ZONES_MMZ
		return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=(1<<c:GetSequence())&ZONES_MMZ
	if zone~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP,zone)
	end
end
function s.mvfilter(c)
    local z=1<<c:GetSequence()
	return c:GetSequence()<5 and c:IsSetCard(0x17e) and ( c:CheckAdjacent() or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,(z<<1|z>>1)&0x1f)>0)
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
    if tc:IsLocation(LOCATION_MZONE) then
		tc:MoveAdjacent()
	elseif tc:IsLocation(LOCATION_SZONE) then
        local seq=tc:GetSequence()
        if seq>4 then return end
        local flag=0
        if seq>0 and Duel.CheckLocation(tp,LOCATION_SZONE,seq-1) then flag=flag|(0x1<<seq-1) end
        if seq<4 and Duel.CheckLocation(tp,LOCATION_SZONE,seq+1) then flag=flag|(0x1<<seq+1) end
        if flag==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        local zone=math.log(Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,~(flag<<8)),2)-8
        Duel.MoveSequence(tc,zone,LOCATION_SZONE)
    end
end

function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLevelAbove,1,nil,5,c,SUMMON_TYPE_FUSION) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetLabel()==1 or Duel.GetFlagEffect(tp,id)>0
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x17e),tp,LOCATION_ONFIELD,0,nil)
    local thg=Group.CreateGroup()
    for oc in (g+dg):Iter() do
        thg:Merge(oc:GetColumnGroup():Filter(s.thfilter,nil,1-tp))
    end
    dg:Sub(thg)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
end
function s.thfilter(c,p)
	return c:IsAbleToHand() and c:IsControler(p)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x17e),tp,LOCATION_ONFIELD,0,nil)
    local thg=Group.CreateGroup()
    for oc in (g+dg):Iter() do
        thg:Merge(oc:GetColumnGroup():Filter(s.thfilter,nil,1-tp))
    end
    dg:Sub(thg)
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.limitval(e,c)
	local ec=e:GetHandler()
    local seq=ec:GetSequence()
	if seq==5 then 
		return ~(1<<(8-e:GetHandler():GetSequence()))
	elseif seq==6 then 
		return ~(1<<(7-e:GetHandler():GetSequence()))
	else
		local zone=(1<<(4-seq))
		local t={7,nil,8}
		if ec:IsSequence(1,3) then
			zone=zone|(1<<(t[seq]-seq))
		end
        return ~zone
	end
end