
module PS2Format
  class OperationType

    @@expense = {}
    @@expense[:water] = "01"
    @@expense[:gas] = "02"
    @@expense[:electricity] = "03"
    @@expense[:gas_electricity] = "04"
    @@expense[:cellphone] = "05"
    @@expense[:telex] = "06"
    @@expense[:house_rent] = "07"
    @@expense[:payroll] = "08"
    @@expense[:suppliers] = "09"
    @@expense[:transfer] = "12"

    @@income = {}
    @@income[:water] = "51"
    @@income[:gas] = "52"
    @@income[:electricity] = "53"
    @@income[:gas_electricity] = "54"
    @@income[:cellphone] = "55"
    @@income[:telex] = "56"
    @@income[:house_rent] = "57"
    @@income[:land_public_service] = "58"
    @@income[:suppliers] = "59"
    @@income[:insurance] = "60"
    @@income[:quota] = "61"
    @@income[:transfer] = "62"
    @@income[:data_com_public_service] = "63"
    @@income[:collect] = "64"
    @@income[:rented_circuits] = "65"
    @@income[:various_services] = "66"
    @@income[:sanitation] = "67"
    @@income[:water_electricity] = "68"
    @@income[:water_sanitation] = "69"
    @@income[:telecom_ctt] = "70"
    @@income[:iva_refund_iva_charge] = "71"
    @@income[:tv_license] = "72"
    @@income[:TELEBIP] = "73"
    @@income[:VIDEOTEX] = "74"
    @@income[:digital_phone] = "75"
    @@income[:green_number] = "76"
    @@income[:phone_porto] = "77"
    @@income[:green_number_IN] = "78"
    @@income[:blue_number] = "79"
    @@income[:rented_circuits_porto] = "80"
    @@income[:CLIP] = "81"

    def self.expense
      @@expense
    end

    def self.income
      @@income
    end

  end
end
