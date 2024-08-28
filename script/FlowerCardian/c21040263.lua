--Flower Cardian Plum
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
    --Cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
    --synchro
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
    --Draw
	local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
s.listed_series={0xe6}
function s.tgfilter(c,tp,bool)
	local tg_check=nil
	if bool then
		tg_check=c:IsAbleToGrave()
	else
		tg_check=c:IsAbleToGraveAsCost()
	end
	return tg_check and Duel.GetMZoneCount(tp,c)>0 and c:IsSetCard(0xe6) and c:IsLevelAbove(5)
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsAttackBelow(1000)
end

function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) 
		or sg:CheckWithSumEqual(function() return 2 end,lv,#sg,#sg)
	return res,true
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local rc=c:GetReasonCard()
	return r&REASON_SYNCHRO==REASON_SYNCHRO and rc:GetMaterialCount()>2
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Draw(p,1,REASON_EFFECT)
end