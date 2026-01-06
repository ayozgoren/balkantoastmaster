classdef ToastLogic < handle
    % TOASTLOGIC - Business Logic (Math & State)
    
    properties
        CurrentCredit
        SelectedProduct
        SpiceCount 
    end 
    
    methods
        function obj = ToastLogic()
            obj.CurrentCredit = 0;
            obj.SpiceCount = 0;
            obj.SelectedProduct = [];
        end
        
        function addMoney(obj, amount)
            obj.CurrentCredit = obj.CurrentCredit + amount;
        end
        
        function setProduct(obj, productStruct)
            obj.SelectedProduct = productStruct;
        end
        
        function changeSpice(obj, delta)
            newVal = obj.SpiceCount + delta;
            if newVal >= 0 && newVal <= 10
                obj.SpiceCount = newVal;
            end
        end
        
        function [success, msg, change] = tryPurchase(obj)
            if isempty(obj.SelectedProduct)
                success = false; 
                msg = 'Select a product first!'; 
                change = 0;
                return;
            end
            
            cost = obj.SelectedProduct.Price;
            
            if obj.CurrentCredit >= cost
                success = true;
                change = obj.CurrentCredit - cost;
                msg = sprintf('Enjoy your %s!', obj.SelectedProduct.Name);
                
                obj.CurrentCredit = 0;
                obj.SpiceCount = 0;
                obj.SelectedProduct = [];
            else
                success = false;
                missing = cost - obj.CurrentCredit;
                msg = sprintf('Missing %.2f KM', missing);
                change = 0;
            end
        end
    end
end