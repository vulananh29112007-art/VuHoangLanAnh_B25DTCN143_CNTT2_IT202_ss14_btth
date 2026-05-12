use RikkeiClinicDB;

delimiter //

create procedure ProcessEquipmentPurchase(
    in p_patient_id int,
    in p_product_id int,
    in p_quantity int,
    out p_message varchar(100)
)
begin

    -- biến
    declare v_price decimal(18,2);
    declare v_stock int;
    declare v_total_price decimal(18,2);
    declare v_status varchar(20);
    declare v_balance decimal(18,2);

    start transaction;

    -- lấy thông tin sản phẩm
    select price, stock
    into v_price, v_stock
    from Products
    where product_id = p_product_id;

    -- lấy thông tin ví
    select balance, status
    into v_balance, v_status
    from Wallets
    where patient_id = p_patient_id;

    -- tính tổng tiền
    set v_total_price = v_price * p_quantity;

    -- kiểm tra tồn kho
    if v_stock < p_quantity then

        set p_message = 'Thất bại: Kho không đủ sản phẩm';
        rollback;

    -- kiểm tra ví khóa
    elseif v_status = 'Inactive' then
        rollback;
        set p_message = 'Thất bại: Ví đang bị khóa';
        

    -- kiểm tra đủ tiền
    elseif v_balance < v_total_price then
    
        rollback;
        set p_message = 'Thất bại: Số dư ví không đủ';

    else

        -- trừ kho
        update Products
        set stock = stock - p_quantity
        where product_id = p_product_id;

        -- trừ tiền ví
        update Wallets
        set balance = balance - v_total_price
        where patient_id = p_patient_id;

        commit;

        set p_message = 'Thành công: Đã xử lý đơn hàng';

    end if;

end //

delimiter ;