
if Server then

    function AlienCommander:BuildCystChain(start)
        local cystPoints, parent, normals = GetCystPoints(start, self:GetTeamNumber())
        
        local team = self:GetTeam()
        local cost = math.max(0, (#cystPoints - 1) * kCystCost)

        if cost <= team:GetTeamResources() and parent ~= nil then

            local previousParent
            local createdCysts = 0

            for i = 2, #cystPoints do

                local cyst = CreateEntity(Cyst.kMapName, cystPoints[i], self:GetTeamNumber())
                cyst:SetCoords(AlignCyst(Coords.GetTranslation(cystPoints[i]), normals[i]))

                cyst:SetImmuneToRedeploymentTime(0.05)

                if not cyst:GetIsConnected() and previousParent then
                    cyst:ChangeParent(previousParent)
                end

                previousParent = cyst
                createdCysts = createdCysts + 1

            end

            if createdCysts > 0 then
                team:AddTeamResources(-createdCysts * kCystCost)
                return true
            end
        end
    end
end