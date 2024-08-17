--Vaylantz Nile – Nexus
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,{21040185,21040186}),extrafil=s.extrafil,
								extraop=s.extraop,location=LOCATION_HAND,extratg=s.extratg})
    e1:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e1)
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,{21040185,21040186}),extrafil=s.extrafil,
                                extraop=s.extraop,location=LOCATION_DECK,extratg=s.extratg})
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCondition(s.ritcon)
	c:RegisterEffect(e2)
end
s.listed_series={0x17e}
s.fit_monster={21040185,21040186}
function s.ritcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,49568943),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.mfilter(c)
	return c:HasLevel() and c:IsSetCard(0x17e) and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,75952542),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_SZONE,0,nil)
	end
	return Group.CreateGroup()
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_SZONE):Filter(s.mfilter,nil)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_SZONE)
end