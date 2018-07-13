

-- this just bothered me
GUIMarineHUD.kNumInitSquares = 45
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
        animatedSquare:FadeOut(0.5 + i/GUIMarineHUD.kNumInitSquares, nil, AnimateLinear,
            function (self, item)
                item:Destroy()
            end
            )
    
    end

end