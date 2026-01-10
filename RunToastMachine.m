function RunToastMachine()
    Logic = ToastLogic();
    Theme = ToastConfig.getTheme();
    ProcessFiles = ToastConfig.getProcessImages();
    AudioFiles = ToastConfig.getAudioFiles();
    coinBtns = gobjects(0);
    isProcessing = false; 
    
    fig = uifigure('Name', 'Balkan Toast Master', 'Position', [100 100 850 650], 'Color', Theme.Background, 'CloseRequestFcn', @closeApp);
    MainGrid = uigridlayout(fig, [1 1]); MainGrid.Padding = 0;
    MainPanel = uipanel(MainGrid, 'BackgroundColor', Theme.Background, 'BorderType', 'none');
    MainPanel.Layout.Row = 1; MainPanel.Layout.Column = 1;
    pnlPreview = uipanel(MainPanel, 'Position', [500 420 300 200], 'BackgroundColor', Theme.DetailPanel);
    avatarSource = ''; if exist('toast_avatar.png', 'file'), avatarSource = 'toast_avatar.png'; end
    imgAvatar = uiimage(pnlPreview, 'Position', [25 25 250 150], 'ImageSource', avatarSource, 'ScaleMethod', 'fit');
    lblStatus = uilabel(pnlPreview, 'Position', [10 5 280 20], 'Text', 'Select a product!', 'FontColor', 'white', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    pnlProducts = uipanel(MainPanel, 'Position', [20 420 460 210], 'BackgroundColor', Theme.Background, 'BorderType', 'none');
    renderProductButtons();
    pnlFrame = uipanel(MainPanel, 'Position', [30 180 420 230], 'BackgroundColor', [0.5 0.5 0.5]);
    imgSource = ''; if exist(ProcessFiles.Idle, 'file'), imgSource = ProcessFiles.Idle; end
    imgProcess = uiimage(pnlFrame, 'Position', [10 10 400 210], 'ImageSource', imgSource, 'ScaleMethod', 'stretch');
    for k = 1:length(Logic.CoinInventory)
        val = Logic.CoinInventory(k).Val; x = 30 + (k-1)*65;
        coinBtns(k) = ToastComponents.createCoinBtn(MainPanel, x, 80, val, @(src,e) coinInsertedCallback(val));
    end
    btnConfirm = uibutton(MainPanel, 'Position', [600 360 120 40], 'Text', 'CONFIRM', 'BackgroundColor', Theme.ConfirmGreen, 'FontColor', 'white', 'FontSize', 14, 'FontWeight', 'bold', 'ButtonPushedFcn', @confirmCallback);
    lamp = uilamp(MainPanel, 'Position', [740 370 20 20], 'Color', [0.2 0.4 0.2]);
    lblSpiceHeader = createLabel(MainPanel, [500 290 80 30], 'Spice');
    createLabel(MainPanel, [500 230 80 30], 'Money'); createLabel(MainPanel, [500 170 80 30], 'Change');
    dispSpice = ToastComponents.createDarkPanel(MainPanel, [640 290 50 30]);
    dispMoney = ToastComponents.createDarkPanel(MainPanel, [600 230 80 30]);
    dispChange = ToastComponents.createDarkPanel(MainPanel, [600 170 80 30]);
    btnSpiceMinus = uibutton(MainPanel, 'Position', [600 290 30 30], 'Text', '-', 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', 'Enable', 'off', 'ButtonPushedFcn', @(s,e) spiceCallback(-1));
    btnSpicePlus = uibutton(MainPanel, 'Position', [700 290 30 30], 'Text', '+', 'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', 'Enable', 'off', 'ButtonPushedFcn', @(s,e) spiceCallback(1));
    btnTakeChange = uibutton(MainPanel, 'Position', [600 120 100 30], 'Text', 'Take Change', 'BackgroundColor', Theme.Button, 'FontColor', 'white', 'ButtonPushedFcn', @takeChangeCallback);
    uibutton(MainPanel, 'Position', [750 20 80 30], 'Text', 'Settings', 'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'white', 'ButtonPushedFcn', @openSettingsMenu);
    lblClock = uilabel(MainPanel, 'Position', [530 20 200 30], 'Text', datestr(now, 'dd-mm-yyyy HH:MM:SS'), 'FontColor', [0.7 0.7 0.7], 'FontSize', 14, 'HorizontalAlignment', 'right');
    lblTemp = uilabel(MainPanel, 'Position', [450 20 80 30], 'Text', sprintf('%.0f °C', Logic.Temperature), 'FontColor', [1 0.6 0], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    tmr = timer('ExecutionMode', 'fixedRate', 'Period', 1.0, 'TimerFcn', @updateClockAndPhysics);
    start(tmr);
    AdminPanel = uipanel(MainGrid, 'BackgroundColor', Theme.Background); AdminPanel.Visible = 'off'; AdminPanel.Layout.Row = 1; AdminPanel.Layout.Column = 1;
    uilabel(AdminPanel, 'Position', [20 600 400 30], 'Text', 'ADMINISTRATOR MODE', 'FontSize', 18, 'FontWeight', 'bold', 'FontColor', 'white');
    uilabel(AdminPanel, 'Position', [20 570 300 20], 'Text', 'Edit values directly in the table below:', 'FontColor', 'white');
    tblProducts = uitable(AdminPanel, 'Position', [20 350 430 200], 'ColumnName', {'ID', 'Product Name', 'Price (KM)', 'Stock Qty'}, 'ColumnEditable', [false, false, true, true], 'ColumnWidth', {'fit', 'fit', 'fit', 'fit'});
    axTemp = uiaxes(AdminPanel, 'Position', [470 300 350 250], 'BackgroundColor', [0.95 0.95 0.95]);
    try, axTemp.Toolbar.Visible = 'off'; catch, end
    title(axTemp, 'Temp. History (Last 30s)'); xlabel(axTemp, 'Time (sec)'); ylabel(axTemp, 'Temp (°C)'); axTemp.XGrid = 'on'; axTemp.YGrid = 'on';
    tblCoins = uitable(AdminPanel, 'Position', [20 150 300 180], 'ColumnName', {'Coin Value', 'Stock Qty'}, 'ColumnEditable', [false, true], 'ColumnWidth', {140, 100});
    uibutton(AdminPanel, 'Position', [470 260 150 30], 'Text', 'Fill product stocks', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) fillProductStocks());
    uibutton(AdminPanel, 'Position', [470 220 150 30], 'Text', 'Clear product stocks', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) clearProductStocks());
    uibutton(AdminPanel, 'Position', [470 180 150 30], 'Text', 'Fill coin stocks 80%', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) fillCoinStocks());
    uibutton(AdminPanel, 'Position', [470 140 150 30], 'Text', 'Clear coin stocks', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) clearCoinStocks());
    uibutton(AdminPanel, 'Position', [650 260 180 30], 'Text', 'Reset Temp', 'BackgroundColor', [0.8 0.4 0.2], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) resetTemperature());
    uibutton(AdminPanel, 'Position', [650 220 180 30], 'Text', 'Open Inventory (XLSX)', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) openFileSafe('inventory.xlsx'));
    uibutton(AdminPanel, 'Position', [650 180 180 30], 'Text', 'Open Activity Log (TXT)', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) openFileSafe('log.txt'));
    uibutton(AdminPanel, 'Position', [650 140 180 30], 'Text', 'Open Temp Log (TXT)', 'BackgroundColor', [0.2 0.4 0.6], 'FontColor', 'white', 'ButtonPushedFcn', @(~,~) openFileSafe('temperature_log.txt'));
    uibutton(AdminPanel, 'Position', [650 50 150 40], 'Text', 'SAVE & EXIT', 'BackgroundColor', Theme.ConfirmGreen, 'FontColor', 'white', 'FontSize', 14, 'ButtonPushedFcn', @saveAndCloseAdmin);
    uibutton(AdminPanel, 'Position', [480 50 150 40], 'Text', 'CANCEL', 'BackgroundColor', [0.6 0.2 0.2], 'FontColor', 'white', 'FontSize', 14, 'ButtonPushedFcn', @(s,e) switchMode('user'));
    function toggleInterface(state)
        btns = pnlProducts.Children; for i = 1:length(btns), btns(i).Enable = state; end
        for i = 1:length(coinBtns), coinBtns(i).Enable = state; end
        btnTakeChange.Enable = state; btnConfirm.Enable = state;
        if strcmp(state, 'off'), btnSpiceMinus.Enable='off'; btnSpicePlus.Enable='off';
        else
            if ~isempty(Logic.SelectedProduct) && Logic.SelectedProduct.ID~=6, btnSpiceMinus.Enable='on'; btnSpicePlus.Enable='on';
            else, btnSpiceMinus.Enable='off'; btnSpicePlus.Enable='off'; end
        end
    end
    function confirmCallback(~, ~)
        currentID = 0; if ~isempty(Logic.SelectedProduct), currentID = Logic.SelectedProduct.ID; end
        [success, msg, ~] = Logic.tryPurchase();
        if success
            % Start Processing (Non-Blocking)
            isProcessing = true;
            toggleInterface('off');
            lblStatus.Text = 'Preparing...'; lamp.Color = 'green';
            
            % Audio Setup
            audioFile = '';
            if currentID <= 3
                if exist(ProcessFiles.Active, 'file'), imgProcess.ImageSource = ProcessFiles.Active; end
                audioFile = AudioFiles.Cook;
            elseif currentID >= 4
                audioFile = AudioFiles.Fill;
            end
            playDuration = 5.0; % Default / Minimum duration
            if exist(audioFile, 'file')
                try
                    [y, Fs] = audioread(audioFile);
                    playDuration = length(y) / Fs;
                    sound(y, Fs);
                catch
                end
            end
            
            % Start Physics with Duration
            Logic.startCooking(currentID, playDuration);
            % NO PAUSE HERE: Logic handled in updateClockAndPhysics
        else, uialert(fig, msg, 'Transaction Error'); lamp.Color='red'; lblStatus.Text=msg; end
    end
    function updateClockAndPhysics(~, ~)
        try
            lblClock.Text = datestr(now, 'dd-mm-yyyy HH:MM:SS'); 
            Logic.updateTemperature(1.0);
            lblTemp.Text = sprintf('%.0f °C', Logic.Temperature);
            
            if Logic.Temperature > 150, lblTemp.FontColor=[1 0 0]; else, lblTemp.FontColor=[1 0.6 0]; end
            
            % Check if cooking just finished
            if isProcessing && ~Logic.IsCooking
                isProcessing = false;
                if exist(ProcessFiles.Idle,'file'), imgProcess.ImageSource=ProcessFiles.Idle; end
                dispMoney.Text = sprintf('%.2f', Logic.CurrentCredit); dispChange.Text = '0.00';
                lblStatus.Text = 'Enjoy!'; dispSpice.Text = '0';
                if exist('toast_avatar.png','file'), imgAvatar.ImageSource = 'toast_avatar.png'; end
                renderProductButtons(); toggleInterface('on');
            end
            
            if strcmp(AdminPanel.Visible, 'on'), updateAdminGraph(); end
        catch, end
    end
    function updateAdminGraph()
        try
            fid = fopen('temperature_log.txt', 'r'); if fid == -1, return; end
            data = textscan(fid, '%s %s %f %*s'); fclose(fid);
            dates=data{1}; times=data{2}; temps=data{3}; if isempty(dates), return; end
            fullDT = strcat(dates, {' '}, times); tStamps = datetime(fullDT, 'InputFormat', 'dd-MM-yyyy HH:mm:ss');
            [tStamps, uIdx] = unique(tStamps); temps = temps(uIdx);
            currentTime = datetime('now'); relSeconds = seconds(tStamps - currentTime);
            mask = relSeconds >= -30 & relSeconds <= 0;
            validTimes = relSeconds(mask); validTemps = temps(mask);
            plot(axTemp, validTimes, validTemps, 'LineWidth', 2, 'Color', [1 0.6 0]);
            xlim(axTemp, [-30, 0]); ylim(axTemp, [0, 200]);
        catch, end
    end
    function fillCoinStocks()
        data = tblCoins.Data;
        for i = 1:size(data, 1)
            val = double(data{i, 1});
            qty = int32(data{i, 2});
            if qty < 40
                needed = 40 - qty; addedValue = double(needed) * val;
                data{i, 2} = int32(40);
                Logic.writeLog(sprintf('ADMIN ADDED %.2f KM', addedValue));
            end
        end
        tblCoins.Data = data;
    end
    function coinInsertedCallback(val)
        idx = find([Logic.CoinInventory.Val] == val, 1);
        if ~isempty(idx)
            currentStock = Logic.CoinInventory(idx).Stock;
            if currentStock >= 50
                uialert(fig, sprintf('Coin Box Full! Cannot accept %.2f KM coin.', val), 'Insert Error', 'Icon', 'warning');
                return;
            end
        end
        Logic.addMoney(val); dispMoney.Text = sprintf('%.2f', Logic.CurrentCredit);
        if ~isempty(Logic.SelectedProduct)
            liveProd = Logic.SelectedProduct;
            if Logic.CurrentCredit >= liveProd.Price && liveProd.Stock > 0, lamp.Color = 'green'; end
        end
    end
    function openFileSafe(f), try, if ispc, winopen(f); else, open(f); end; catch, uialert(fig, ['Error: ' f], 'Error'); end; end
    function resetTemperature(), Logic.Temperature=25; Logic.writeTempLog(Logic.Temperature); updateClockAndPhysics(tmr,[]); uialert(fig,'Reset to 25°C','Success'); end
    function fillProductStocks(), d=tblProducts.Data; for i=1:size(d,1), d{i,4}=int32(20); end; tblProducts.Data=d; end
    function clearProductStocks(), d=tblProducts.Data; for i=1:size(d,1), d{i,4}=int32(0); end; tblProducts.Data=d; end
    function clearCoinStocks(), d=tblCoins.Data; for i=1:size(d,1), d{i,2}=int32(0); end; tblCoins.Data=d; end
    function closeApp(~,~), stop(tmr); delete(tmr); delete(fig); end
    function renderProductButtons(), delete(pnlProducts.Children); prods=Logic.ProductInventory; for i=1:length(prods), p=prods(i); col=1+mod(i-1,2); row=ceil(i/2); x=10+(col-1)*220; y=150-(row-1)*70; ToastComponents.createProductBtn(pnlProducts,x,y,p,@(btn,e)selectItemCallback(p)); end; end
    function selectItemCallback(p), Logic.setProduct(p); if isempty(Logic.SelectedProduct), return; end; pLive=Logic.SelectedProduct; Logic.SpiceCount=0; dispSpice.Text='0'; switch pLive.ID, case {1,2,3}, lblSpiceHeader.Text='Ketchup'; btnSpiceMinus.Enable='on'; btnSpicePlus.Enable='on'; case 4, lblSpiceHeader.Text='Sugar'; btnSpiceMinus.Enable='on'; btnSpicePlus.Enable='on'; case 5, lblSpiceHeader.Text='Salt'; btnSpiceMinus.Enable='on'; btnSpicePlus.Enable='on'; case 6, lblSpiceHeader.Text=''; btnSpiceMinus.Enable='off'; btnSpicePlus.Enable='off'; otherwise, lblSpiceHeader.Text='Spice'; btnSpiceMinus.Enable='on'; btnSpicePlus.Enable='on'; end; lblStatus.Text=sprintf('%s (%d left)',pLive.Name,pLive.Stock); if pLive.Stock<=0, lblStatus.Text='OUT OF STOCK'; lblStatus.FontColor='red'; lamp.Color='red'; else, lblStatus.FontColor='cyan'; lamp.Color='yellow'; end; if exist(pLive.DetailImageFile,'file'), imgAvatar.ImageSource=pLive.DetailImageFile; else, if exist('toast_avatar.png','file'), imgAvatar.ImageSource='toast_avatar.png'; end; end; end
    function spiceCallback(d), Logic.changeSpice(d); dispSpice.Text=num2str(Logic.SpiceCount); end
    function takeChangeCallback(~,~), amt=Logic.CurrentCredit; if amt>0, if ~Logic.checkChangeAvailable(amt), uialert(fig,'Apologies, the machine cannot dispense the exact change at this moment.','Error','Icon','warning'); Logic.writeLog(sprintf('Error: Unable to dispense change - %.2f KM',amt)); return; end; Logic.dispenseChange(amt); end; Logic.CurrentCredit=0; Logic.SelectedProduct=[]; Logic.SpiceCount=0; dispMoney.Text='0.00'; dispChange.Text=sprintf('%.2f',amt); dispSpice.Text='0'; lblSpiceHeader.Text='Spice'; btnSpiceMinus.Enable='off'; btnSpicePlus.Enable='off'; lamp.Color=[0.2 0.4 0.2]; lblStatus.Text='Select a product!'; lblStatus.FontColor='white'; if exist('toast_avatar.png','file'), imgAvatar.ImageSource='toast_avatar.png'; else, imgAvatar.ImageSource=''; end; end
    function openSettingsMenu(~,~), sel=uiconfirm(fig,'Select:','Settings','Options',{'Admin Mode','Close Program','Cancel'},'DefaultOption',3,'CancelOption',3); switch sel, case 'Close Program', closeApp(); case 'Admin Mode', askForPassword(); end; end
    function askForPassword(), d=inputdlg({'Enter Admin Password:'},'Auth',[1 40]); if isempty(d), return; end; if strcmp(d{1},ToastConfig.getAdminPassword()), loadAdminData(); switchMode('admin'); else, uialert(fig,'Incorrect Password!','Denied','Icon','error'); Logic.writeLog('Error: Admin Authentication Failed'); end; end
    function switchMode(m), if strcmp(m,'admin'), MainPanel.Visible='off'; AdminPanel.Visible='on'; updateAdminGraph(); else, AdminPanel.Visible='off'; MainPanel.Visible='on'; renderProductButtons(); end; end
    function loadAdminData(), p=Logic.ProductInventory; dP=cell(length(p),4); for i=1:length(p), dP{i,1}=p(i).ID; dP{i,2}=p(i).Name; dP{i,3}=p(i).Price; dP{i,4}=p(i).Stock; end; tblProducts.Data=dP; c=Logic.CoinInventory; dC=cell(length(c),2); for i=1:length(c), dC{i,1}=c(i).Val; dC{i,2}=c(i).Stock; end; tblCoins.Data=dC; end
    function saveAndCloseAdmin(~,~), dP=tblProducts.Data; dC=tblCoins.Data; cP=Logic.ProductInventory; for i=1:length(cP), cP(i).Price=cell2mat(dP(i,3)); cP(i).Stock=int32(cell2mat(dP(i,4))); end; cC=Logic.CoinInventory; for i=1:length(cC), cC(i).Stock=int32(cell2mat(dC(i,2))); end; Logic.updateAdminData(cP,cC); uialert(fig,'Settings Saved.','Success'); switchMode('user'); end
    function lbl=createLabel(p,pos,txt), lbl=uilabel(p,'Position',pos,'Text',txt,'FontColor','white','FontSize',12,'FontWeight','bold'); end
end
