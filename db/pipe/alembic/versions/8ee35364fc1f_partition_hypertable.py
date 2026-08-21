"""partition hypertable

Revision ID: 8ee35364fc1f
Revises: 98012c59e86d
Create Date: 2026-08-20 17:53:35.159053

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8ee35364fc1f'
down_revision: Union[str, Sequence[str], None] = '98012c59e86d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
	# Create hypertable manually or via extension
    connection = op.get_bind()
    connection.execute(sa.text("""
        SELECT create_hypertable('sensor_data', 'delivered_at',
                                 number_partitions => 8);
    """))
    connection.commit()
    pass
		

def downgrade() -> None:
    """Downgrade schema."""
    pass
