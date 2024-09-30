run "test_bucket_name_is_valid" {

    command = apply # Can be plan, apply or destroy

    variables {
        environment = "dev"
        archivos = {
            "1.txt" = "Contenido 1"
            "2.txt" = "Contenido 2"
            "3.txt" = "Contenido 3"
        }
    }

    assert {
        condition = strcontains(aws_s3_bucket.bucket.bucket, "enrique-test-terraform-dev")
        error_message = "El nombre del bucket no es valido"
    }

    assert {
        condition = length(aws_s3_object.archivos) == 3
        error_message = "El numero de archivos subidos es invalido"
    }

    assert {
        #alltrue(list bools) True if all true
        #anytrue(list bools) True if any true
        # Checquear si el nombre de los archivos coincide
        condition = alltrue([for s3_object in aws_s3_object.archivos: anytrue([for var_key, var_value in var.archivos: s3_object.key == var_key])])
        error_message = "Los nombres de los archivos generados no coinciden"
    }

}


run "bucket_prefix_is_valid" {

    command = plan

    variables {
        environment = "dev"
    }

    assert {
        condition = aws_s3_bucket.bucket.bucket_prefix == "enrique-test-terraform-dev"
        error_message = "El prefijo no es adecuado"
    }
}