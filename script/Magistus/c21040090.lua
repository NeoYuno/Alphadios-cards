--Hera, the Magistus of Prophecy
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
	--Equip or destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rmcon)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)   
end
s.listed_series={SET_MAGISTUS}
function s.eqfilter(c)
	return c:IsSetCard(SET_MAGISTUS) and c:IsMonster() and c:GetLevel()~=4
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local sel=0
		if Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) then sel=sel+1 end
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_STZONE,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
	elseif sel==1 then
		Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		Duel.SelectOption(tp,aux.Stringid(id,2))
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	else
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_STZONE,0,nil)
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
        if ec then
            Duel.Equip(tp,ec,c,true)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            e1:SetLabelObject(c)
            ec:RegisterEffect(e1)
        end
	else
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_STZONE,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_STZONE,0,1,1,nil)
            if #g<=0 or Duel.Destroy(g,REASON_EFFECT)<=0 or c:IsLevelAbove(12) then return end
            local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)
            if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                local lv=Duel.AnnounceLevel(tp,1,ct)
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(lv)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e1)
            end
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.egfilter(c,tp)
    if not c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK) then return false end
    return c:IsPreviousSetCard(SET_MAGISTUS) and c:IsMonster() and c:IsReason(REASON_EFFECT) and c:GetPreviousLocation()==LOCATION_SZONE
        and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_EXTRA,1,nil,c)
end
function s.rmfilter(c,tc)
    return c:IsAbleToRemove() and c:GetType()==tc:GetType()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_EXTRA,nil,eg:GetFirst())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(1-tp,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
end