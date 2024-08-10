--Chemicritter Amber Ant
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
    --indestructable
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --Fusion Summon
	local params={nil}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetCondition(Gemini.EffectStatusCondition)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
						if not e:GetHandler():IsRelateToEffect(e) then return end
						Fusion.SummonEffOP(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp)
					end)
	c:RegisterEffect(e2)
end