

-- this just bothered me
GUIMarineHUD.kNumInitSquares = 60
function GUIMarineHUD:TriggerInitAnimations()

    self.scanLeft:SetColor(Color(1,1,1,0.8))
    --self.scanLeft:SetSize(Vector(1200, 1200, 0), 1)
    self.scanLeft:FadeIn(0.3, nil, AnimateLinear, 
        function (self)        
            self.scanLeft:FadeOut(0.5, nil, AnimateQuadratic)
        end
        )
    
    self.scanRight:SetColor(Color(1,1,1,0.8))
    --self.scanRight:SetSize(Vector(-1200, 1200, 0), 1)
    self.scanRight:FadeIn(0.3, nil, AnimateLinear, 
        function (self)        
            self.scanRight:FadeOut(0.5, nil, AnimateQuadratic)
        end
        )
        
    -- create random squares that fade out
    for i = 1, GUIMarineHUD.kNumInitSquares do
    
        local animatedSquare = self:CreateAnimatedGraphicItem()
        
        local randomPos = Vector(
                    math.random(0, 1920/GUIMarineHUD.kInitSquareSize.x) * GUIMarineHUD.kInitSquareSize.x, 
                    math.random(0, 1200/GUIMarineHUD.kInitSquareSize.y) * GUIMarineHUD.kInitSquareSize.y, 
                    0)
         
        animatedSquare:SetUniformScale(self.scale)           
        animatedSquare:SetPosition(randomPos)
        animatedSquare:SetSize(GUIMarineHUD.kInitSquareSize)
        animatedSquare:SetColor(GUIMarineHUD.kInitSquareColors)
        animatedSquare:FadeOut(0.1 + i/GUIMarineHUD.kNumInitSquares, nil, AnimateQuadratic,
            function (self, item)
                item:Destroy()
            end
            )
    
    end

end


local oldUpdate = GUIMarineHUD.Update
function GUIMarineHUD:Update(deltaTime)
	oldUpdate(self, deltaTime)
	
    local player = Client.GetLocalPlayer()
	if player then
	
		if not player._GUI_shove then
			player._GUI_shove = 0
		end
		local shove = GUIScale(player._GUI_shove * 1.25)
		if shove < 1 then
			shove = 0
		end
		self.background:SetPosition( Vector(0, shove, 0) )
		
	else
	
		self.background:SetPosition( Vector(0, 0, 0) )
		
	end
end