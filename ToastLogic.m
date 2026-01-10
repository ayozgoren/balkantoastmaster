classdef ToastLogic < handle
    % TOASTLOGIC - Non-Blocking Physics Engine
    
    properties
        CurrentCredit
        SelectedProduct
        SpiceCount
        Temperature
        IsCooking
        CookingStartTime
        CookingDuration 
        CookingProductID
        TargetTemp
        LastLogTime
        ProductInventory
        CoinInventory
    end
    properties (Constant)
        ExcelFile = 'inventory.xlsx';
        LogFile = 'log.txt';
        TempLogFile = 'temperature_log.txt';
        BaseTemp = 25;
    end
    methods
        function obj = ToastLogic()
            obj.CurrentCredit = 0;
            obj.SpiceCount = 0;
            obj.SelectedProduct = [];
            obj.Temperature = obj.BaseTemp;
            obj.IsCooking = false;
            obj.CookingProductID = 0;
            obj.LastLogTime = now;
            obj.writeTempLog(obj.Temperature);
            if exist(obj.ExcelFile, 'file')
                try
                    T_Prod = readtable(obj.ExcelFile, 'Sheet', 'Products');
                    T_Prod.Stock = int32(T_Prod.Stock);
                    obj.ProductInventory = table2struct(T_Prod);
                    T_Coins = readtable(obj.ExcelFile, 'Sheet', 'Coins');
                    T_Coins.Stock = int32(T_Coins.Stock);
                    obj.CoinInventory = table2struct(T_Coins);
                catch
                    obj.loadDefaults();
                end
            else
                obj.loadDefaults();
            end
        end
        function updateTemperature(obj, dt)
            % Check if cooking time is over
            if obj.IsCooking
                elapsed = (now - obj.CookingStartTime) * 86400;
                if elapsed >= obj.CookingDuration
                    obj.stopCooking();
                end
            end

            if obj.IsCooking
                elapsed = (now - obj.CookingStartTime) * 86400;
                switch obj.CookingProductID
                    case {5, 6} % Drinks: Cool fast
                        if obj.Temperature > obj.BaseTemp
                            obj.Temperature = obj.Temperature - 2;
                            if obj.Temperature < obj.BaseTemp, obj.Temperature = obj.BaseTemp; end
                        end
                    case 4 % Tea
                        if obj.Temperature > 100
                            obj.Temperature = obj.Temperature - 2;
                        else
                            if elapsed <= 5
                                if obj.Temperature < 100
                                    remaining = 100 - obj.Temperature;
                                    step = remaining * 0.5;
                                    obj.Temperature = obj.Temperature + step;
                                else
                                    obj.Temperature = 100;
                                end
                            end
                        end
                    case {1, 2, 3} % Toast
                        if elapsed <= 5
                            if obj.Temperature < obj.TargetTemp
                                remaining = obj.TargetTemp - obj.Temperature;
                                step = remaining * 0.4;
                                obj.Temperature = obj.Temperature + step;
                            else
                                obj.Temperature = obj.TargetTemp;
                            end
                        end
                end
            else
                % Idle: Cool slow
                if obj.Temperature > obj.BaseTemp
                    obj.Temperature = obj.Temperature - 1;
                else
                    obj.Temperature = obj.BaseTemp;
                end
            end
            
            % Log every second for graph continuity
            if (now - obj.LastLogTime) * 86400 >= 1
                obj.writeTempLog(obj.Temperature);
                obj.LastLogTime = now;
            end
        end
        function startCooking(obj, productID, duration)
            obj.IsCooking = true;
            obj.CookingStartTime = now;
            obj.CookingDuration = duration;
            obj.CookingProductID = productID;
            if ismember(productID, [1, 2, 3])
                if obj.Temperature < 100
                    obj.TargetTemp = 180;
                elseif obj.Temperature >= 100 && obj.Temperature < 150
                    obj.TargetTemp = 200;
                else
                    obj.TargetTemp = 200;
                end
            else
                obj.TargetTemp = 0;
            end
        end
        function stopCooking(obj)
            obj.IsCooking = false;
            obj.CookingProductID = 0;
        end
        function [success, msg, change] = tryPurchase(obj)
            change = 0;
            if isempty(obj.SelectedProduct), success=false; msg='Select a product first!'; obj.writeLog('Error: No Selection'); return; end
            idx = find([obj.ProductInventory.ID] == obj.SelectedProduct.ID, 1);
            liveProd = obj.ProductInventory(idx);
            if obj.Temperature > 150 && ismember(liveProd.ID, [1, 2, 3])
                success = false;
                msg = 'Safety Error: Too Hot! Wait for < 150°C';
                obj.writeLog(sprintf('Error: Overheat Protection (%.1f C)', obj.Temperature));
                return;
            end
            if liveProd.Stock <= 0, success=false; msg='Sorry, out of stock.'; obj.writeLog(sprintf('Error: Stock %s', liveProd.Name)); return; end
            if obj.CurrentCredit < liveProd.Price
                success=false; missing=liveProd.Price-obj.CurrentCredit; msg=sprintf('Missing %.2f KM', missing);
                obj.writeLog(sprintf('Error: Funds %s', liveProd.Name)); return;
            end
            success = true;
            obj.CurrentCredit = obj.CurrentCredit - liveProd.Price;
            msg = sprintf('Enjoy your %s!', liveProd.Name);
            obj.writeLog(sprintf('Ordered %s', liveProd.Name));
            obj.ProductInventory(idx).Stock = obj.ProductInventory(idx).Stock - 1;
            obj.saveToExcel();
            obj.SpiceCount = 0;
            obj.SelectedProduct = [];
        end
        function writeTempLog(obj, tempVal)
            try, fid=fopen(obj.TempLogFile, 'a'); if fid~=-1, fprintf(fid, '%s %.1f C\r\n', datestr(now, 'dd-mm-yyyy HH:MM:SS'), tempVal); fclose(fid); end; catch; end
        end
        function writeLog(obj, message)
            try, fid=fopen(obj.LogFile,'a'); if fid~=-1, fprintf(fid,'%s %s\r\n', datestr(now,'dd-mm-yyyy HH:MM:SS'), message); fclose(fid); end; catch; end
        end
        function loadDefaults(obj)
            obj.ProductInventory = ToastConfig.getProducts();
            obj.CoinInventory = ToastConfig.getCoins();
            obj.saveToExcel();
        end
        function saveToExcel(obj)
            try, T_Prod = struct2table(obj.ProductInventory); T_Coins = struct2table(obj.CoinInventory); writetable(T_Prod, obj.ExcelFile, 'Sheet', 'Products'); writetable(T_Coins, obj.ExcelFile, 'Sheet', 'Coins'); catch; end
        end
        function updateAdminData(obj, newProdData, newCoinData)
            obj.ProductInventory = newProdData; obj.CoinInventory = newCoinData; obj.saveToExcel(); obj.writeLog('Admin updated inventory/prices');
            if ~isempty(obj.SelectedProduct), obj.setProduct(obj.SelectedProduct); end
        end
        function addMoney(obj, amount)
            obj.CurrentCredit = obj.CurrentCredit + amount; idx = find([obj.CoinInventory.Val] == amount, 1);
            if ~isempty(idx), obj.CoinInventory(idx).Stock = obj.CoinInventory(idx).Stock + 1; end
            if floor(amount)==amount, obj.writeLog(sprintf('Add %.0f KM', amount)); else, obj.writeLog(sprintf('Add %.2f KM', amount)); end
        end
        function isPossible = checkChangeAvailable(obj, amountRequired)
            remaining = amountRequired; epsilon = 0.001; tempStock = obj.CoinInventory;
            for i = length(tempStock):-1:1
                coinVal = tempStock(i).Val;
                while remaining >= (coinVal - epsilon) && tempStock(i).Stock > 0, remaining = remaining - coinVal; tempStock(i).Stock = tempStock(i).Stock - 1; end
            end
            if remaining < epsilon, isPossible = true; else, isPossible = false; end
        end
        function dispenseChange(obj, amountToReturn)
            remaining = amountToReturn; epsilon = 0.001; logParts = {};
            for i = length(obj.CoinInventory):-1:1
                coinVal = obj.CoinInventory(i).Val; count = 0;
                while remaining >= (coinVal - epsilon) && obj.CoinInventory(i).Stock > 0, remaining = remaining - coinVal; obj.CoinInventory(i).Stock = obj.CoinInventory(i).Stock - 1; count = count + 1; end
                if count > 0, if floor(coinVal)==coinVal, logParts{end+1}=sprintf('%d*%.0fKM',count,coinVal); else, logParts{end+1}=sprintf('%d*%.2fKM',count,coinVal); end, end
            end
            obj.saveToExcel(); if ~isempty(logParts), logStr = strjoin(logParts, '+'); obj.writeLog(sprintf('Taking Change %s', logStr)); end
        end
        function setProduct(obj, productStruct)
            idx = find([obj.ProductInventory.ID] == productStruct.ID, 1);
            if ~isempty(idx), obj.SelectedProduct = obj.ProductInventory(idx); end
        end
        function changeSpice(obj, delta)
            newVal = obj.SpiceCount + delta; if newVal >= 0 && newVal <= 10, obj.SpiceCount = newVal; end
        end
    end
end
