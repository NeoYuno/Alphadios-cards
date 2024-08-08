--Superheavy Samurai Soulshogi
local s,id=GetID()
function s.initial_effect(c)
	--Equip itself
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    --cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9a))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    --def atk
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    --search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
s.listed_series={0x9a}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(0x9a) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,0x9a),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,0x9a),tp,LOCATION_MZONE,0,1,1,nil)
    local c=e:GetHandler()
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
    if c:IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
    end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
        return Duel.SendtoGrave(c,REASON_RULE)
    end
    if Duel.Equip(tp,c,tc) then
        --Equip limit registration
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetCode(EFFECT_EQUIP_LIMIT)
        e0:SetReset(RESET_EVENT|RESETS_STANDARD)
        e0:SetValue(function(e,c) return c==e:GetLabelObject() end)
        e0:SetLabelObject(tc)
        c:RegisterEffect(e0)
    end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	return des:IsLocation(LOCATION_GRAVE) and des:IsMonster() and rc:IsRelateToBattle() and rc==e:GetHandler():GetEquipTarget()
        and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end