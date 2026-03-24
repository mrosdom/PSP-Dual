package com.example.psp;

import com.example.psp.entity.Employee;

import com.example.psp.repository.EmployeeRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class PspDualApplication {

    public static void main(String[] args) {
        SpringApplication.run(PspDualApplication.class, args);
    }

    @Bean
    CommandLineRunner initDatabase(EmployeeRepository repository) {
        return args -> {
            if (repository.count() == 0) {
                repository.save(new Employee(null, "Juan Perez", "juan@example.com", "Desarrollador", "IT"));
                repository.save(new Employee(null, "Maria Garcia", "maria@example.com", "Manager", "RRHH"));
                System.out.println("[INFO] Datos de ejemplo cargados en la base de datos.");
            }
        };
    }
}

