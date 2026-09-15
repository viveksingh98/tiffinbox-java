package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Three of the four collaborators here belong to somebody else: Connection, PreparedStatement
 * and ResultSet are JDBC's; only Database is ours. The stubs were written by reading the
 * repository, so they agree with it - including about the column name.
 */
@ExtendWith(MockitoExtension.class)
class MockedJdbcTest {

    @Mock Database db;
    @Mock Connection connection;
    @Mock PreparedStatement statement;
    @Mock ResultSet rows;

    @Test
    void findAllReturnsTheRoster() throws Exception {
        when(db.open()).thenReturn(connection);
        when(connection.prepareStatement(anyString())).thenReturn(statement);
        when(statement.executeQuery()).thenReturn(rows);
        when(rows.next()).thenReturn(true, false);
        when(rows.getString("name")).thenReturn("Ravi");
        when(rows.getInt("meals_per_day")).thenReturn(2);
        when(rows.getInt("price_per_meal")).thenReturn(120);
        when(rows.getString("meal_typ")).thenReturn("VEG");

        assertThat(new CustomerRepository(db).findAll())
            .containsExactly(new Customer("Ravi", 2, 120, "VEG"));
    }
}
