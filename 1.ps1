
        if (-NOT (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\1")) {
            try {
                New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\1" -Force
                Write-Output "Registry key '1' created successfully."
            } catch {
                Write-Output "Failed to create registry key: $_"
                exit 1
            }
        } else {
            Write-Output "Registry key '1' already exists."
        }
        